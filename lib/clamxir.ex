defmodule Clamxir do
  defstruct check: false,
            daemonize: false,
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

  iex> Clamxir.scanner_exists?(%Clamxir{check: true})
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

  @doc """
  Return boolean with the result if succeded.  Otherwhise, a tuple with {:error, message}

  ## Examples

  iex> Clamxir.virus?(%Clamxir{}, "README.md")
  false

  iex> Clamxir.virus?(%Clamxir{}, "NOT_FOUND.md")
  {:error, "NOT_FOUND.md not found."}
  """
  def virus?(%Clamxir{} = clamxir_config, path) do
    %{clamxir_config: clamxir_config, path: path}
    |> check_file_presence
    |> check_scanner_presence
    |> check_virus
  end

  def safe?(%Clamxir{} = clamxir_config, path), do: !virus?(clamxir_config, path)

  defp check_file_presence(%{clamxir_config: clamxir_config, path: path}) do
    case file_exists?(path) do
      {:error, message} -> {:error, message}
      {:ok, path} -> %{clamxir_config: clamxir_config, path: path}
    end
  end

  defp check_scanner_presence({:error, _} = status), do: status

  defp check_scanner_presence(%{clamxir_config: clamxir_config, path: path}) do
    case check_scanner(clamxir_config) do
      true -> %{clamxir_config: clamxir_config, path: path}
      false -> {:error, "Scanner not found."}
    end
  end

  defp check_virus({:error, _} = status), do: status

  defp check_virus(%{clamxir_config: clamxir_config, path: path}) do
    run_command(clamxir_config, path)
  end

  defp run_command(clamxir_config, path) do
    clamd_executable_name(clamxir_config.daemonize)
    |> System.cmd(create_args(clamxir_config, path))
    |> check_virus_scann_results()
  end

  defp create_args(clamxir_config, path) do
    command_args =
      []
      |> add_fdpass(clamxir_config)
      |> add_stream(clamxir_config)

    command_args ++ [path, "--no-summary"]
  end

  defp add_fdpass(command, %Clamxir{fdpass: fdpass, daemonize: daemonize})
      when fdpass == true and daemonize == true,
      do: command ++ ["--fdpass"]

  defp add_fdpass(command, _), do: command

  defp add_stream(command, %Clamxir{stream: stream, daemonize: daemonize})
      when stream == true and daemonize == true,
      do: command ++ ["--stream"]

  defp add_stream(command, _), do: command

  defp check_scanner(%Clamxir{daemonize: daemonize}) do
    daemonize
    |> clamd_executable_name()
    |> System.cmd(["--version", "--quiet"])
    |> check_system_results
  end

  defp check_system_results({_, 0}), do: true
  defp check_system_results(_), do: false

  defp check_virus_scann_results({_, 0}), do: false
  defp check_virus_scann_results({message, 2}), do: {:error, message}
  defp check_virus_scann_results(_), do: true

  defp clamd_executable_name(daemonize) when daemonize == true, do: "clamdscan"
  defp clamd_executable_name(_), do: "clamscan"
end
