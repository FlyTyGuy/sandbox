require 'octokit'
require 'csv'
require 'time'

# Replace with your GitHub token
client = Octokit::Client.new(access_token: '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')

# Replace with your repository details
owner = 'FlyTyGuy'
repo = 'sandbox'

# Fetch open and closed pull requests
prs = client.pull_requests("#{owner}/#{repo}", state: 'all')

# Open CSV file for writing
CSV.open("pull_request_data.csv", "w") do |csv|
  # Write CSV header
  csv << ['PR Title', 'Author', 'Merged By', 'Additions', 'Deletions', 'Created At', 'Merged At', 'Time Difference (hrs)']

  # Iterate through pull requests
  prs.each do |pr|
    # Fetch the pull request details
    pr_details = client.pull_request("#{owner}/#{repo}", pr.number)

    # Calculate the time difference between creation and merge
    created_at = Time.parse(pr_details.created_at)
    merged_at = pr_details.merged_at ? Time.parse(pr_details.merged_at) : nil
    time_diff = merged_at ? (merged_at - created_at) / 3600 : nil

    # Fetch the user who merged the PR (for this exercise, we'll assume it's the same person)
    merged_by = pr_details.user.login

    # Write PR details to CSV
    csv << [
      pr_details.title,
      pr_details.user.login,        # Author
      merged_by,                    # Merged by
      pr_details.additions,         # Additions
      pr_details.deletions,         # Deletions
      created_at,                   # Created At
      merged_at || 'Not Merged',    # Merged At
      time_diff.nil? ? 'N/A' : time_diff.round(2)  # Time Difference in hours
    ]
  end
end

puts "Pull request data has been saved to 'pull_request_data.csv'"
