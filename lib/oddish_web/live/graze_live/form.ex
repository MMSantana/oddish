defmodule OddishWeb.GrazeLive.Form do
  use OddishWeb, :live_view

  alias Oddish.Grazes
  alias Oddish.Grazes.Graze

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage graze records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="graze-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:flock_type]} type="text" label="Flock type" />
        <.input field={@form[:flock_quantity]} type="number" label="Flock quantity" />
        <.input field={@form[:start_date]} type="date" label="Start date" />
        <.input field={@form[:end_date]} type="date" label="End date" />
        <.input field={@form[:planned_period]} type="number" label="Planned period" />
        <.input field={@form[:status]} type="text" label="Status" />
        <.input field={@form[:solta_id]} type="number" label="Solta" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Graze</.button>
          <.button navigate={return_path(@current_scope, @return_to, @graze)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    graze = Grazes.get_graze!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Graze")
    |> assign(:graze, graze)
    |> assign(:form, to_form(Grazes.change_graze(socket.assigns.current_scope, graze)))
  end

  defp apply_action(socket, :new, _params) do
    graze = %Graze{org_id: socket.assigns.current_scope.organization.id}

    socket
    |> assign(:page_title, "New Graze")
    |> assign(:graze, graze)
    |> assign(:form, to_form(Grazes.change_graze(socket.assigns.current_scope, graze)))
  end

  @impl true
  def handle_event("validate", %{"graze" => graze_params}, socket) do
    changeset =
      Grazes.change_graze(socket.assigns.current_scope, socket.assigns.graze, graze_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"graze" => graze_params}, socket) do
    save_graze(socket, socket.assigns.live_action, graze_params)
  end

  defp save_graze(socket, :edit, graze_params) do
    case Grazes.update_graze(socket.assigns.current_scope, socket.assigns.graze, graze_params) do
      {:ok, graze} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lote atualizado")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, graze)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_graze(socket, :new, graze_params) do
    case Grazes.create_graze(socket.assigns.current_scope, graze_params) do
      {:ok, graze} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lote criado")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, graze)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(scope, "index", _graze), do: ~p"/o/#{scope.organization.slug}/grazes"
  defp return_path(scope, "show", graze), do: ~p"/o/#{scope.organization.slug}/grazes/#{graze}"
end
