//   Declare your outputs here!
//
//   Outputs will be displayed in the terminal of the Terraform run after a
//   successful destroy/apply.

output "hey_there" {
  value = "${var.greeting}! You are ready to terraform in ${var.gcp_project_us}"
}

output "your_project_number" {
  value = data.google_project.project.number
}