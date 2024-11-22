defmodule AzureOpenAI do
  @moduledoc """
  Module to interact with Azure OpenAI API.
  """

  @api_key System.get_env("AZURE_OPENAI_API_KEY")
  @endpoint System.get_env("AZURE_OPENAI_ENDPOINT")

  @headers [
    {"Content-Type", "application/json"},
    {"Authorization", "Bearer #{@api_key}"}
  ]

  def review_code(code_snippet) do
    body = %{
      "prompt" => code_snippet,
      "max_tokens" => 1024
    }
    |> Jason.encode!()

    case :hackney.request(:post, @endpoint, @headers, body, [:with_body]) do
      {:ok, 200, _, response_body} ->
        {:ok, Jason.decode!(response_body)}

      {:ok, status, _, response_body} ->
        {:error, "Failed with status: #{status}, response: #{response_body}"}

      {:error, reason} ->
        {:error, "Request failed: #{reason}"}
    end
  end
end
