import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.inputTarget.addEventListener("input", this.search.bind(this))
  }

  search() {
    const query = this.inputTarget.value
    fetch(`/jobs/search?q=${encodeURIComponent(query)}`, {
      headers: { 'Accept': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
      const jobsTable = document.getElementById('jobs-table')
      const dashboardJobsTable = document.getElementById('dashboard-jobs-table')
      if (jobsTable) jobsTable.querySelector('tbody').innerHTML = data.rows
      if (dashboardJobsTable) dashboardJobsTable.querySelector('tbody').innerHTML = data.rows
    })
  }
}
