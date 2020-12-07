defmodule MemzWeb.GameLive.Play do
  use MemzWeb, :live_view

  alias Memz.Game

  @default_text ""
  @default_steps 0

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(changeset: Game.change_game(default_game(), %{}))
     |> assign(guess_changeset: Game.game_changeset())
     |> assign(eraser: nil)
     |> assign(submitted: false)}
  end

  @impl true
  def render(%{eraser: nil} = assigns) do
    ~L"""
    <h1>What do you want to memorize?</h1>

    <%= f = form_for @changeset, "#",
        phx_change: "validate",
        phx_submit: "save" %>

      <%= label f, :steps %>
      <%= number_input f, :steps %>
      <%= error_tag f, :steps %>

      <%= label f, :text %>
      <%= text_input f, :text %>
      <%= error_tag f, :text %>

      <%= submit "Memorize", disabled: !@changeset.valid? %>
    </form>
    """
  end

  def render(%{eraser: %{status: :erasing}} = assigns) do
    ~L"""
    <h1>Memorize this much!</h1>
    <pre>
      <%= @eraser.text %>
    </pre>
    <button phx-click="erase">Erase some</button>

    <%= score(@eraser) %>
    """
  end

  def render(%{eraser: %{status: :guessing}} = assigns) do
    ~L"""
    <h1>Type the text, filling in the blanks!</h1>
    <pre>
      <%= @eraser.text %>
    </pre>

    <%= f = form_for @guess_changeset, "#",
        phx_submit: "guess", as: "guess" %>

      <%= label f, :text %>
      <%= text_input f, :text %>
      <%= error_tag f, :text %>

      <%= submit "Type the text" %>
    </form>
    """
  end

  def render(%{live_action: :over} = assigns) do
    ~L"""
    <h1>Game Over!</h1>
    <h2>Your score: <%= @eraser.score %></h2>
    <button phx-click="play">Play again?</button>
    """
  end

  defp score(eraser) do
    """
    <h2>Your score is #{eraser.score} so far.</h2>
    <h5>Lower scores are better</h5>
    """
    |> Phoenix.HTML.raw()
  end

  defp score(socket, guess) do
    socket
    |> assign(eraser: Game.score(socket.assigns.eraser, guess))
  end

  defp validate(socket, params) do
    socket
    |> assign(changeset: Game.change_game(default_game(), params))
  end

  defp memorize(socket, params) do
    eraser =
      default_game()
      |> Game.change_game(params)
      |> Game.create()

    socket
    |> assign(eraser: eraser)
  end

  defp default_game(), do: Game.new_game(@default_text, @default_steps)

  defp erase(socket) do
    socket
    |> assign(eraser: Game.erase(socket.assigns.eraser))
  end

  defp maybe_finish(%{assigns: %{eraser: %{status: :finished}}} = socket) do
    push_patch(socket, to: "/game/over")
  end

  defp maybe_finish(socket), do: socket

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"game" => params}, socket) do
    {:noreply, validate(socket, params)}
  end

  @impl true
  def handle_event("save", %{"game" => params}, socket) do
    {:noreply, memorize(socket, params)}
  end

  @impl true
  def handle_event("erase", _params, socket) do
    {:noreply, erase(socket)}
  end

  @impl true
  def handle_event("guess", %{"guess" => %{"text" => guess}}, socket) do
    {:noreply, socket |> score(guess) |> maybe_finish()}
  end
end
