defmodule Mix.Tasks.ReviewJava do
  use Mix.Task

  def run(_) do
    # Replace these with the actual repository owner and name
    repo_owner = "davithss"
    repo_name = "test-java-code"
    pr_number = System.get_env("PR_NUMBER")
    token = System.get_env("GITHUB_TOKEN")

    JavaReview.review_pr(repo_owner, repo_name, pr_number, token)
  end
end
