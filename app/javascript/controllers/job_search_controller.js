import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.inputTarget.addEventListener("input", this.search.bind(this))
  }

  search() {
    const query = this.inputTarget.value
    fetch(`/jobs/search?q=${encodeURIComponent(query)}`, {
      headers: { 'Accept': 'text/javascript' }
    })
    .then(response => response.text())
    .then(js => eval(js))
  }
}
