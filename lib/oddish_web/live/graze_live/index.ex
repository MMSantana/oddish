defmodule OddishWeb.GrazeLive.Index do
  use OddishWeb, :live_view

  alias Oddish.Grazes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Manejo
        <:actions>
          <.button
            variant="primary"
            navigate={~p"/o/#{@current_scope.organization.slug}/grazes/history"}
          >
            <.icon name="hero-plus" /> Histórico
          </.button>
          <.button variant="primary" navigate={~p"/o/#{@current_scope.organization.slug}/grazes/new"}>
            <.icon name="hero-plus" /> Novo lote
          </.button>
        </:actions>
      </.header>
      <h1 :if={@has_planned_grazes}>Lotes planejados</h1>
      <.table
        :if={@has_planned_grazes}
        id="planned_grazes"
        rows={@streams.planned_grazes}
        row_click={
          fn {_id, graze} ->
            JS.navigate(~p"/o/#{@current_scope.organization.slug}/grazes/#{graze}")
          end
        }
      >
        <:col :let={{_id, graze}} label="Solta">{graze.solta.name}</:col>
        <:col :let={{_id, graze}} label="Data inicial">{graze.start_date}</:col>
        <:col :let={{_id, graze}} label="Duração planejada">{graze.planned_period} dias</:col>
        <:col :let={{_id, graze}} label="Data final">{graze.end_date}</:col>
        <:col :let={{_id, graze}} label="Tipo">
          {String.capitalize(Atom.to_string(graze.pack.flock_type))}
        </:col>
        <:col :let={{_id, graze}} label="Quantidade">{graze.pack.animal_count}</:col>
        <:action :let={{id, graze}}>
          <div class="sr-only">
            <.link navigate={~p"/o/#{@current_scope.organization.slug}/grazes/#{graze}"}>Show</.link>
          </div>
          <.link
            phx-click={JS.push("start_graze", value: %{id: graze.id}) |> hide("##{id}")}
            data-confirm="Começar o lote?"
          >
            Começar
          </.link>
        </:action>
        <:action :let={{id, graze}}>
          <.link
            phx-click={JS.push("delete", value: %{id: graze.id}) |> hide("##{id}")}
            data-confirm="Quer mesmo deletar este lote"
          >
            Delete
          </.link>
        </:action>
      </.table>

      <div :if={@has_ongoing_grazes && @has_planned_grazes} class="divider divider-primary"></div>

      <h1 :if={@has_ongoing_grazes}>Lotes em andamento</h1>
      <.table
        :if={@has_ongoing_grazes}
        id="ongoing_grazes"
        rows={@streams.ongoing_grazes}
        row_click={
          fn {_id, graze} ->
            JS.navigate(~p"/o/#{@current_scope.organization.slug}/grazes/#{graze}")
          end
        }
      >
        <:col :let={{_id, graze}} label="Solta">{graze.solta.name}</:col>
        <:col :let={{_id, graze}} label="Data inicial">{graze.start_date}</:col>
        <:col :let={{_id, graze}} label="Duração planejada">{graze.planned_period} dias</:col>
        <:col :let={{_id, graze}} label="Data final">{graze.end_date}</:col>
        <:col :let={{_id, graze}} label="Tipo">
          {String.capitalize(Atom.to_string(graze.pack.flock_type))}
        </:col>
        <:col :let={{_id, graze}} label="Quantidade">{graze.pack.animal_count}</:col>
        <:action :let={{id, graze}}>
          <div class="sr-only">
            <.link navigate={~p"/o/#{@current_scope.organization.slug}/grazes/#{graze}"}>Show</.link>
          </div>
          <.link
            phx-click={JS.push("end_graze", value: %{id: graze.id}) |> hide("##{id}")}
            data-confirm="Encerrar o lote?"
          >
            Encerrar
          </.link>
        </:action>
        <:action :let={{id, graze}}>
          <.link
            phx-click={JS.push("delete", value: %{id: graze.id}) |> hide("##{id}")}
            data-confirm="Quer mesmo deletar este lote?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Grazes.subscribe_grazes(socket.assigns.current_scope)
    end

    planned_grazes = list_planned_grazes(socket.assigns.current_scope)
    ongoing_grazes = list_ongoing_grazes(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Lista de manejos")
     |> assign(:has_planned_grazes, length(planned_grazes) > 0)
     |> assign(:has_ongoing_grazes, length(ongoing_grazes) > 0)
     |> stream(:planned_grazes, planned_grazes)
     |> stream(:ongoing_grazes, ongoing_grazes)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    graze = Grazes.get_graze!(socket.assigns.current_scope, id)
    {:ok, _} = Grazes.delete_graze(socket.assigns.current_scope, graze)

    {:noreply, stream_delete(socket, :grazes, graze)}
  end

  @impl true
  def handle_event("start_graze", %{"id" => id}, socket) do
    graze = Grazes.get_graze!(socket.assigns.current_scope, id)
    {:ok, _} = Grazes.start_planned_graze(socket.assigns.current_scope, graze)

    {:noreply, stream_delete(socket, :planned_grazes, graze)}
  end

  @impl true
  def handle_event("end_graze", %{"id" => id}, socket) do
    graze = Grazes.get_graze!(socket.assigns.current_scope, id)
    {:ok, _} = Grazes.end_ongoing_graze(socket.assigns.current_scope, graze)

    {:noreply, stream_delete(socket, :ongoing_grazes, graze)}
  end

  @impl true
  def handle_info({type, %Oddish.Grazes.Graze{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     socket
     |> stream(:ongoing_grazes, list_ongoing_grazes(socket.assigns.current_scope), reset: true)
     |> stream(:planned_grazes, list_planned_grazes(socket.assigns.current_scope), reset: true)}
  end

  defp list_planned_grazes(current_scope) do
    Grazes.list_grazes_by_status(current_scope, :planned) |> Oddish.Repo.preload([:pack])
  end

  defp list_ongoing_grazes(current_scope) do
    Grazes.list_grazes_by_status(current_scope, :ongoing) |> Oddish.Repo.preload([:pack])
  end
end
