defmodule Clamxir do
  defstruct daemonize: false,
            fdpass: false,
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

  @doc """
  Returns a tuple if the scanner exists

  ## Examples

    iex> Clamxir.scanner_exists?(%Clamxir{})
    true
  """
  def scanner_exists?(%Clamxir{check: check} = clamxir_config) do
    case check do
      false ->
        true

      _ ->
        check_scanner(clamxir_config)
    end
  end

  defp check_scanner(%Clamxir{daemonize: daemonized}) do
    daemonized
    |> clamd_executable_name()
    |> System.cmd(["--version", "--quiet"])
    |> check_system_results
  end

  defp check_system_results({_, 0}), do: true
  defp check_system_results(_), do: false

  defp clamd_executable_name(daemonized) when daemonized == true, do: "clamdscan"
  defp clamd_executable_name(_), do: "clamscan"
end
