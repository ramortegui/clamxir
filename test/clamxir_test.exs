defmodule ClamxirTest do
  use ExUnit.Case, async: true
  doctest Clamxir

  @path "./malware.txt"

  setup_all do
    {:ok, {{_, 200, 'OK'}, _headers, body}} =
      :httpc.request(:get, {'http://www.eicar.org/download/eicar.com', []}, [],
        body_format: :binary
      )

    :ok = File.write(@path, body)

    on_exit(fn ->
      File.rm(@path)
    end)
  end

  describe "Clamxir.safe?" do
    test 'check a file with malware' do
      result_safe = Clamxir.safe?(%Clamxir{}, @path)
      assert(result_safe == false, "It's not safe.")

      result_virus = Clamxir.virus?(%Clamxir{}, @path)
      assert(result_virus == true, "It's a virus.")
    end

    test 'check a file with malware running with daemonize' do
      result_safe = Clamxir.safe?(%Clamxir{daemonize: true}, @path)
      assert(result_safe == false, "It's not safe.")

      result_virus = Clamxir.virus?(%Clamxir{daemonize: true}, @path)
      assert(result_virus == true, "It's a virus.")
    end
  end
end
