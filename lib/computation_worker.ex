require Logger

defmodule ComputationWorker do
  use GenServer, restart: :temporary

  @boss_name "boss_server"

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(worker_name) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(worker_name))
  end

  defp via_tuple(worker_name) do
    {:via, Registry, {:my_reg, worker_name}}
  end

  def init(_) do
    state = []
    {:ok, state}
  end

  def handle_call(:get_results,_from, state) do
    {:reply, state, state}
  end

  def handle_cast({:compute, num_chunk}, _state) do
    vampires = Vampire.find_vampire(num_chunk)
    GenServer.cast(via_tuple(@boss_name), {:print, vampires})
    {:noreply, :ok}
  end
end

