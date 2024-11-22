defmodule JavaReview do
  alias Tentacat.Client
  alias Tentacat.PullRequests.Comments
  alias AzureOpenAI

  @doc """
  Reviews Java files and comments on PR.
  """
  def review_pr(repo_owner, repo_name, pr_number, token) do
    client = Client.new(%{access_token: token})

    files = get_changed_files(client, repo_owner, repo_name, pr_number)

    Enum.each(files, fn file ->
      if String.ends_with?(file["filename"], ".java") do
        analyze_file(file, client, repo_owner, repo_name, pr_number)
      end
    end)
  end

  defp get_changed_files(client, repo_owner, repo_name, pr_number) do
    Tentacat.PullRequests.Files.list(repo_owner, repo_name, pr_number, client)
  end

  defp analyze_file(file, client, repo_owner, repo_name, pr_number) do
    file_content = File.read!(file["filename"])

    {:ok, analysis} = AzureOpenAI.review_code(file_content)
    comments = parse_analysis(analysis)

    Enum.each(comments, fn {line, comment} ->
      add_comment(client, repo_owner, repo_name, pr_number, file["filename"], line, comment)
    end)
  end

  defp parse_analysis(analysis) do
    # Parse the analysis received from Azure OpenAI
    # and return list of {line, comment}
    []
  end

  defp add_comment(client, repo_owner, repo_name, pr_number, file, line, comment) do
    Comments.create(repo_owner, repo_name, pr_number, %{
      body: comment,
      path: file,
      position: line
    }, client)
  end
end
