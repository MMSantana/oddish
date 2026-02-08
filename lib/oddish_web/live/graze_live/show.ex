defmodule OddishWeb.GrazeLive.Show do
  use OddishWeb, :live_view

  alias Oddish.Grazes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Manejo {@graze.id}
        <:actions>
          <.button navigate={~p"/o/#{@current_scope.organization.slug}/grazes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/o/#{@current_scope.organization.slug}/grazes/#{@graze}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Editar manejo
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Solta">{@graze.solta.name}</:item>
        <:item title="Lote">{@graze.pack.name}</:item>
        <:item title="Tipo de rebanho">
          {String.capitalize(Atom.to_string(@graze.pack.flock_type))}
        </:item>
        <:item title="Quantidade de animais">{@graze.pack.animal_count}</:item>
        <:item title="Data inicial">{@graze.start_date}</:item>
        <:item title="Data final">{@graze.end_date}</:item>
        <:item title="Período planejado">{@graze.planned_period} dias</:item>
        <:item title="Status">{Oddish.Grazes.Graze.present_status(@graze.status)}</:item>
        <:item title="Estado"><.on_time? graze={@graze} /></:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Grazes.subscribe_grazes(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Detalhes do manejo")
     |> assign(
       :graze,
       Grazes.get_graze!(socket.assigns.current_scope, id) |> Oddish.Repo.preload([:pack])
     )}
  end

  @impl true
  def handle_info(
        {:updated, %Oddish.Grazes.Graze{id: id} = graze},
        %{assigns: %{graze: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :graze, graze)}
  end

  def handle_info(
        {:deleted, %Oddish.Grazes.Graze{id: id}},
        %{assigns: %{graze: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "O manejo foi deletado")
     |> push_navigate(to: ~p"/o/#{socket.assigns.current_scope.organization.slug}/grazes")}
  end

  def handle_info({type, %Oddish.Grazes.Graze{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  defp on_time?(assigns) do
    ~H"""
    <div class={
      cond do
        @graze.end_date == nil ->
          "badge badge-warning"

        Date.after?(Date.add(@graze.start_date, @graze.planned_period), @graze.end_date) ->
          "badge badge-success"

        true ->
          "badge badge-error"
      end
    }>
    </div>
    """
  end
end
