import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "button"]

  connect() {
    this.collectedFiles = new DataTransfer()
  }

  select() {
    this.inputTarget.click()
  }

  preview() {
    // Accumulate newly selected files into the persistent collection
    Array.from(this.inputTarget.files).forEach((file) => {
      this.collectedFiles.items.add(file)
    })

    // Sync the input's file list with the full collection
    this.inputTarget.files = this.collectedFiles.files

    this.#renderPreviews()
  }

  #renderPreviews() {
    // Remove only the NEW file previews (not server-rendered existing photos)
    this.previewTarget.querySelectorAll("[data-new-photo]").forEach(el => el.remove())
    
    const files = this.collectedFiles.files

    // If no new files and no existing photos, hide the preview area
    if (files.length === 0 && this.previewTarget.querySelectorAll("[data-photo-wrapper]").length === 0) {
      this.previewTarget.classList.add("hidden")
      return
    }

    this.previewTarget.classList.remove("hidden")

    Array.from(files).forEach((file, index) => {
      if (!file.type.startsWith("image/")) return

      const wrapper = document.createElement("div")
      wrapper.className = "relative group"
      wrapper.setAttribute("data-new-photo", "")  // Mark as new photo preview

      const img = document.createElement("img")
      img.className = "w-20 h-20 object-cover rounded-lg border border-gray-200 dark:border-gray-600"
      img.src = URL.createObjectURL(file)
      img.onload = () => URL.revokeObjectURL(img.src)

      const removeBtn = document.createElement("button")
      removeBtn.type = "button"
      removeBtn.className = "absolute -top-1.5 -right-1.5 w-5 h-5 bg-red-500 text-white rounded-full flex items-center justify-center text-xs opacity-0 group-hover:opacity-100 transition cursor-pointer"
      removeBtn.innerHTML = "&times;"
      removeBtn.addEventListener("click", () => {
        this.#removeFile(index)
      })

      wrapper.appendChild(img)
      wrapper.appendChild(removeBtn)
      this.previewTarget.appendChild(wrapper)
    })
  }

  removeExisting(event) {
    const photoId = event.params.id
    const wrapper = event.currentTarget.closest("[data-photo-wrapper]")

    const input = document.createElement("input")
    input.type = "hidden"
    input.name = "remove_photos[]"
    input.value = photoId
    this.element.querySelector("form").appendChild(input)

    wrapper.remove()
  }

  #removeFile(indexToRemove) {
    const dt = new DataTransfer()
    const files = this.collectedFiles.files

    Array.from(files).forEach((file, index) => {
      if (index !== indexToRemove) dt.items.add(file)
    })

    this.collectedFiles = dt
    this.inputTarget.files = this.collectedFiles.files
    this.#renderPreviews()
  }
}
