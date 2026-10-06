class ReportedDirectMessagePolicy < ApplicationPolicy
  def show?
    user.admin? && record.open? && record.reportable_type == "DirectMessage"
  end
end
