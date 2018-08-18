defmodule Clamxir do
  defstruct check: false,
            daemonize: false,
            error_clamscan_missing: false,
            error_file_missing: false,
            error_file_virus: false,
            fdpass: false,
            silence_output: false,
            stream: false

  @moduledoc """
  Documentation for Clamxir.
  """

  @doc """
  Returns a tuple with the result of the function.

  ## Examples

      iex> Clamxir.file_exists?("README.md")
      {:ok, "README.md"}

      iex> Clamxir.file_exists?("NO_FILE.md")
      {:error, "NO_FILE.md not found."}
  """

  def file_exists?(path) do
    case File.exists?(path) do
      true -> {:ok, path}
      false -> {:error, "#{path} not found."}
    end
  end
end
