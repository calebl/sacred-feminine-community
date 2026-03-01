import { Controller } from "@hotwired/stimulus"
import Cropper from "cropperjs"

export default class extends Controller {
  static targets = [
    "fileInput",
    "source",
    "preview",
    "previewImage",
    "cropperWrap",
    "existingImage"
  ]

  static values = {
    aspectRatio: { type: Number, default: 3 }
  }

  connect() {
    this.cropper = null
  }

  disconnect() {
    this.#destroyCropper()
  }

  fileSelected(event) {
    const file = event.target.files[0]
    if (!file || !file.type.startsWith("image/")) return

    if (this.hasExistingImageTarget) {
      this.existingImageTarget.classList.add("hidden")
    }

    const reader = new FileReader()
    reader.onload = (e) => {
      this.sourceTarget.src = e.target.result
      this.cropperWrapTarget.classList.remove("hidden")
      this.sourceTarget.onload = () => this.#initCropper()
    }
    reader.readAsDataURL(file)
  }

  // Private

  #initCropper() {
    this.#destroyCropper()

    this.cropper = new Cropper(this.sourceTarget, {
      aspectRatio: this.aspectRatioValue,
      viewMode: 1,
      dragMode: "move",
      autoCropArea: 1,
      responsive: true,
      restore: false,
      guides: true,
      center: true,
      highlight: false,
      cropBoxMovable: true,
      cropBoxResizable: true,
      toggleDragModeOnDblclick: false,
      crop: () => {
        this.#updatePreview()
        this.#debouncedUpdateFile()
      }
    })
  }

  #updatePreview() {
    if (!this.cropper || !this.hasPreviewImageTarget) return

    const canvas = this.cropper.getCroppedCanvas({
      imageSmoothingQuality: "high"
    })

    if (canvas) {
      this.previewImageTarget.src = canvas.toDataURL("image/jpeg", 0.8)
      this.previewTarget.classList.remove("hidden")
    }
  }

  #debouncedUpdateFile() {
    clearTimeout(this._fileTimeout)
    this._fileTimeout = setTimeout(() => this.#updateFileInput(), 300)
  }

  async #updateFileInput() {
    if (!this.cropper) return

    const canvas = this.cropper.getCroppedCanvas({
      imageSmoothingQuality: "high"
    })
    if (!canvas) return

    const blob = await new Promise(r => canvas.toBlob(r, "image/jpeg", 0.92))
    const file = new File([blob], "cropped_header.jpg", { type: "image/jpeg" })
    const dt = new DataTransfer()
    dt.items.add(file)
    this.fileInputTarget.files = dt.files
  }

  #destroyCropper() {
    if (this.cropper) {
      this.cropper.destroy()
      this.cropper = null
    }
  }
}
