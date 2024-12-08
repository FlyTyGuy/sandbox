require 'octokit'
require 'faraday/retry'
require 'csv'
require 'time'

# GitHub token
token = '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'

# Create a new Octokit client with the hardcoded token
client = Octokit::Client.new(access_token: token)

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
    begin
      # Fetch the pull request details
      pr_details = client.pull_request("#{owner}/#{repo}", pr.number)

      # Calculate the time difference between creation and merge
      created_at = Time.parse(pr_details.created_at)
      merged_at = pr_details.merged_at ? Time.parse(pr_details.merged_at) : nil
      time_diff = merged_at ? (merged_at - created_at) / 3600 : nil

      # Fetch the user who merged the PR (GitHub provides this info directly)
      merged_by = pr_details.merged_by ? pr_details.merged_by.login : 'Not Merged'

      # Write PR details to CSV
      csv << [
        pr_details.title,
        pr_details.user.login,        # Author
        merged_by,                    # Merged by
        pr_details.additions,         # Additions
        pr_details.deletions,         # Deletions
        created_at.to_s,              # Created At (convert to string)
        merged_at ? merged_at.to_s : 'Not Merged',    # Merged At (convert to string)
        time_diff.nil? ? 'N/A' : time_diff.round(2)  # Time Difference in hours
      ]
    rescue Octokit::NotFound => e
      # Handle case where the PR is not found
      puts "Pull request ##{pr.number} not found: #{e.message}"
    rescue Octokit::Unauthorized => e
      # Handle unauthorized access (if token is incorrect)
      puts "Unauthorized access: #{e.message}"
    rescue => e
      # Handle other general errors
      puts "Error processing PR ##{pr.number}: #{e.message}"
    end
  end
end

puts "Pull request data has been saved to 'pull_request_data.csv'"
