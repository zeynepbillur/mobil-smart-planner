class Task {
  constructor({
    id,
    title,
    description = "",
    dueDate,
    status = "pending",
    userId,
    categoryId = null
  }) {
    this.id = id;
    this.title = title;
    this.description = description;
    this.dueDate = dueDate;
    this.status = status;
    this.userId = userId;
    this.categoryId = categoryId;
  }

  complete() {
    this.status = "completed";
  }

  isOverdue(currentDate = new Date()) {
    return this.status !== "completed" && new Date(this.dueDate) < currentDate;
  }
}

module.exports = Task;
