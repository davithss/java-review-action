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

  @checklist """
  Please review the following Java code against this checklist:
  1. Check for code duplication giving the same result.
     Example: Two methods calculateTotalPrice() and computeFinalPrice() perform the same logic with minor variations. Refactor these into a single method to avoid redundancy.
  2. Check if Java class/Servlets follow standard naming conventions.
     Example: Class names should be in PascalCase (e.g., OrderService), and method names in camelCase (e.g., processOrder()). A servlet could be named OrderServlet instead of generic names like OServ.
  3. Check if Java class has documentation.
  4. Check if Java class has proper exception & error handling.
     Example: Use try-catch blocks where necessary, and log the error messages properly.
     try {
         Files.readAllLines(Paths.get("config.txt"));
     } catch (IOException e) {
         logger.error("Error reading config file: " + e.getMessage(), e);
     }
  5. Use Exceptions rather than Return codes.
     Example: Replace return codes like return -1; with meaningful exceptions.
     if (user == null) {
         throw new UserNotFoundException("User not found");
     }
  6. Use checked exceptions for recoverable conditions and runtime exceptions for programming errors.
     Example: Use IOException (checked) for file operations and NullPointerException (runtime) for programming logic issues.
     // Checked exception for recoverable condition
     public void readFile(String filePath) throws IOException {
         // File reading logic
     }

     // Runtime exception for programming error
     if (object == null) {
         throw new NullPointerException("Object must not be null");
     }
  7. Don't ignore exceptions & Favor the use of standard exceptions.
     Example: Avoid empty catch blocks and prefer standard exceptions like IllegalArgumentException.
     try {
         int value = Integer.parseInt(input);
     } catch (NumberFormatException e) {
         throw new IllegalArgumentException("Input must be a valid number", e);
     }
  """

  def review_code(code_snippet) do
    prompt = @checklist <> "\n\nJava code:\n" <> code_snippet

    body = %{
      "prompt" => prompt,
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
