defmodule Util.PipeDebug do
  @moduledoc """
  Support the injection of inspect capabilities in an elixir pipe |> pipestream.

  Configuration:

    The entire application can have PipeDebug enabled using the :logger configuration settings.

    For the config/<env>.exs file for the environment in which you wish to enable PipeDebug, add the following
    configuration key:

      enable_pipe_debug: true

    PipeDebug is disabled by default, so setting

      enable_pipe_debug: false

    is superfluous.

    Example:

      config :logger,
        level: debug,
        enable_pipe_debug: true

  Usage:

    To force PipeDebug to log debug messages in the current module regardless of the overally application settings:

    ```
    use Util.PipeDebug, enable_pipe_debug: true
    ```

    To only enable/disable PipeDebug based on the settings for the entire application, invoke it in the following
    manner:

    ```
    use Util.PipeDebug
    ```
  """

  defmacro __using__(options) do
    quote do
      require Logger

      # Do nothing in prod.  Prod should never have debug messages turned on.
      def dbg(:prod, _val, _message) do
      end

      def dbg(:dev, val, message) when is_nil(message) do
        Logger.debug(inspect(val, pretty: true))
      end

      def dbg(:dev, val, message) do
        Logger.debug(fn -> "#{message}: #{inspect(val, pretty: true)}" end)
      end

      def dbg(:test, val, message) when is_nil(message) do
        IO.inspect(val, pretty: true)
      end

      def dbg(:test, val, message) do
        IO.puts("#{message}: #{inspect(val, pretty: true)}")
      end

      @doc """
      Writes an inspection dump of the given object to standard output, optionally preceded by a message.  Used to place
      inspections in the midst of a chain of piped calls.

      ## Parameters

        - val: Value to be inspected.
        - message: optional message to precede the value inspection.
        - opts: options
          - :condition an anonymous function used to check conditions on the debug message.  Allows the user to throttle
            log messages for highly repetitive tasks difficult to comb through in the log.

      ## Returns

        - The value dumped in the inspection, unchanged.

      ## Examples

        iex> %{jazz: "Art", messenger: "Blakey"}
          |> Map.values
          |> Util.PipeDebug.debug("Jazz Message")
          |> Enum.reverse
      """
      @spec debug(any(), binary(), keyword()) :: any()
      def debug(val, message \\ nil, opts \\ []) do
        condition = opts[:condition] || fn _val -> true end

        # Note: exrm removes Mix from the mix.  Mix.env crashes if called in an exrm/distillery production release!
        # If Mix is unavalable, assume prod, so, debugging you need to shut up!  No, you shut up!
        (unquote(options[:enable_pipe_debug]) ||
           Application.get_env(:logger, :enable_pipe_debug, false)) && condition.(val) &&
          dbg((Code.ensure_compiled?(Mix) && Mix.env()) || :prod, val, message)

        val
      end
    end
  end
end
