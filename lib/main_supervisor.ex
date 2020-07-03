require Logger

defmodule MainSupervisor do
  use DynamicSupervisor

  def start_link do
    # Logger.info("#{__MODULE__}: supervisor started")
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_boss(boss_name) do
    # Logger.info("#{__MODULE__}: #{boss_name} started")
    child_spec = {BossServer, boss_name}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def add_worker(worker_name) do
    # Logger.info("#{__MODULE__}: #{worker_name} added")
    child_spec = {ComputationWorker, worker_name}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def remove_worker(worker_pid) do
    DynamicSupervisor.terminate_child(__MODULE__, worker_pid)
  end
end
