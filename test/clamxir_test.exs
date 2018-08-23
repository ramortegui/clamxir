defmodule ClamxirTest do
  use ExUnit.Case
  doctest Clamxir

  @path "./malware.txt"

  describe "Clamxir.safe?" do
    test 'a file with malware' do
      {:ok, {{_, 200, 'OK'}, _headers, body}} =
        :httpc.request(:get, {'http://www.eicar.org/download/eicar.com', []}, [],
          body_format: :binary
        )

      :ok = File.write(@path, body)
      result_safe = Clamxir.safe?(%Clamxir{}, @path)
      assert(result_safe == false, "It's not safe.")

      result_virus = Clamxir.virus?(%Clamxir{}, @path)
      assert(result_virus == true, "It's a virus.")
      :ok = File.rm(@path)
    end
  end
end
