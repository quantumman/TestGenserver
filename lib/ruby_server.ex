defmodule RubyServer do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def cast(server, cmd) do
    GenServer.cast(server, {:cast, cmd})
  end

  def call(server, cmd) do
    GenServer.call(server, {:call, cmd})
  end


  def init(_) do
    {:ok, %{port: start_port, next_id: 1, awaiting: %{}}}
  end

  def handle_cast({:cast, cmd}, state) do
    {_id, state} = send_request(state, {:cast, cmd})
    {:noreply, state}
  end

  def handle_call({:call, cmd}, from, state) do
    {id, state} = send_request(state, {:call, cmd})
    {:noreply, %{state | awaiting: Map.put(state.awaiting, id, from)}}
  end


  def handle_info({port, {:data, response}}, %{port: port} = state) do
    {id, result} = :erlang.binary_to_term(response)
    case state.awaiting[id] do
      nil -> {:noreply, state}
      caller ->
        GenServer.reply(caller, result)
        {:noreply, %{state | awaiting: Map.delete(state.awaiting, id)}}
    end
  end

  def handle_info({port, {:exit_status, status}}, %{port: port}) do
    :erlang.error({:port_exit, status})
  end

  def handle_info(_, state), do: {:noreply, state}


  defp start_port do
    Port.open({:spawn, code}, [:binary, {:packet, 4}, :nouse_stdio, :exit_status])
  end

  defp send_request(state, command) do
    id = state.next_id
    Port.command(state.port, :erlang.term_to_binary({id, command}))
    {id, %{state | next_id: id + 1}}
  end

  defp code do
    ~S"""
      ruby -e '
        require "bundler"
        require "erlang/etf"
        require "stringio"
        @input = IO.new(3)
        @output = IO.new(4)
        @output.sync = true
        def receive_input
          encoded_length = @input.read(4)
          return nil unless encoded_length
          length = encoded_length.unpack("N").first
          @request_id, cmd = Erlang.binary_to_term(@input.read(length))
          cmd
        end
        def send_response(value)
          response = Erlang.term_to_binary(Erlang::Tuple[@request_id, value])
          @output.write([response.bytesize].pack("N"))
          @output.write(response)
          true
        end
        context = binding
        while (cmd = receive_input) do
          if [:call, :cast].include?(cmd[0])
            puts "Ruby: #{cmd[1]}\r"
            res = eval(cmd[1], context)
            puts "Ruby: #{res.inspect}\n\r"
            send_response(res) if cmd[0] == :call
          end
        end
        puts "Ruby: exiting"
      '
    """
  end
end
