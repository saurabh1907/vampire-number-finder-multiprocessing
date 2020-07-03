
defmodule App do
  @boss_name "boss_server"


  @spec main(any, any) :: any
  def main(first, last) do

    if (last < first || first < 0 || last < 0) do
      IO.puts "Invalid range!"
      exit(:shutdown)
    end

    Registry.start_link(keys: :unique, name: :my_reg)
    MainSupervisor.start_link
    MainSupervisor.start_boss(@boss_name)
    GenServer.call(via_tuple(@boss_name), {:process, first, last}, :infinity)
  end

  defp via_tuple(worker_name) do
    {:via, Registry, {:my_reg, worker_name}}
  end
end
