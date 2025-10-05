import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    if (!this.hasInputTarget) {
      console.warn('job-search controller: no input target found')
      return
    }
    console.debug('job-search controller connected')
    this.inputTarget.addEventListener("input", this.search.bind(this))

    // If the input is inside a form, prevent normal submission when JS is enabled
    const form = this.inputTarget.closest('form')
    if (form) {
      form.addEventListener('submit', (e) => {
        // Prevent full-page submit and rely on client-side filtering
        e.preventDefault()
        this.search()
      })
    }
  }

  search() {
    const query = this.inputTarget.value.toLowerCase().trim()
    console.debug('job-search: client filtering for', query)

    // Client-side filtering: fast, reliable, and works without server round-trip.
    const filterTable = (tableId) => {
      const table = document.getElementById(tableId)
      if (!table) return
      const rows = table.querySelectorAll('tbody tr')
      rows.forEach(row => {
        const cells = row.querySelectorAll('td')
        const title = (cells[0] && cells[0].textContent || '').toLowerCase()
        const company = (cells[1] && cells[1].textContent || '').toLowerCase()
        const matches = !query || title.includes(query) || company.includes(query)
        row.style.display = matches ? '' : 'none'
      })
    }

    filterTable('jobs-table')
    filterTable('dashboard-jobs-table')

    // Note: we intentionally do client-side filtering only to keep behavior simple and avoid
    // server-side errors. If you want server-backed search (for larger datasets), we can
    // re-enable the fetch path as a fallback.
  }
}
