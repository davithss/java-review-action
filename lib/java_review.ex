defmodule JavaReview do
  alias Tentacat.Client
  alias Tentacat.PullRequests.Comments

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
    comments = analyze_java_content(file_content)

    Enum.each(comments, fn {line, comment} ->
      add_comment(client, repo_owner, repo_name, pr_number, file["filename"], line, comment)
    end)
  end

  defp analyze_java_content(content) do
    lines = String.split(content, "\n")

    lines
    |> Enum.with_index()
    |> Enum.reduce([], fn {line, index}, acc ->
      if String.match?(line, ~r/^public class \w+/) and !Enum.any?(lines, fn l -> String.starts_with?(l, "/**") end) do
        [{index + 1, "Missing class documentation"} | acc]
      else
        acc
      end
    end)
  end


  defp add_comment(client, repo_owner, repo_name, pr_number, file, line, comment) do
    Comments.create(repo_owner, repo_name, pr_number, %{
      body: comment,
      path: file,
      position: line
    }, client)
  end
end
