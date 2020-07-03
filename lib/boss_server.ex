defmodule BossServer do
  use GenServer

  def start_link(boss_name) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(boss_name))
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call({:process, start, finish},_from, _state) do
    start = if start >= 1000, do: start, else: 1000

    logical_procs = System.schedulers_online()
    range = Enum.count(start..finish)
    worker_count = if(range < logical_procs) do range else logical_procs end
    start_workers(worker_count)

    distribute_work(start,finish, worker_count, logical_procs)

    {:noreply, worker_count}
  end

  def handle_cast({:print, numbers}, state) do
    Enum.each(numbers, fn x ->
      Enum.each(x, fn y ->
        IO.write(y)
        IO.write(" ")
      end)
      IO.puts("")
    end)

    if(state-1<=0) do exit(:shutdown) end

    {:noreply, state - 1}
  end

  def distribute_work(start, finish, worker_count, logical_procs) do
    chunk = if(worker_count < logical_procs) do
              Enum.chunk_every(start..finish, 1)
            else
              Map.values(Enum.group_by(start..finish, fn x -> rem(x,worker_count) end))
            end

    Enum.each(1..worker_count, fn x ->
      GenServer.cast(via_tuple("Worker_" <> Integer.to_string(x)), {:compute, Enum.at(chunk, x-1)})
    end)
  end

  def start_workers(worker_count) do
    Enum.each(1..worker_count, fn x ->
      MainSupervisor.add_worker("Worker_" <> Integer.to_string(x))
      end)
  end

  def stop_workers(worker_count) do
    Enum.each(1..worker_count, fn x ->
      MainSupervisor.remove_worker(via_tuple("Worker_" <> Integer.to_string(x)))
      end)
  end

  defp via_tuple(worker_name) do
    {:via, Registry, {:my_reg, worker_name}}
  end
end

