defmodule OddishWeb.SoltaLive.Form do
  use OddishWeb, :live_view

  alias Oddish.Soltas
  alias Oddish.Soltas.Solta

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage solta records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="solta-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:area]} type="number" label="Area" step="any" />
        <.input field={@form[:grass_type]} type="text" label="Grass type" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Solta</.button>
          <.button navigate={return_path(@current_scope, @return_to, @solta)}>Cancel</.button>
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
    solta = Soltas.get_solta!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Solta")
    |> assign(:solta, solta)
    |> assign(:form, to_form(Soltas.change_solta(socket.assigns.current_scope, solta)))
  end

  defp apply_action(socket, :new, _params) do
    solta = %Solta{org_id: socket.assigns.current_scope.organization.id}

    socket
    |> assign(:page_title, "New Solta")
    |> assign(:solta, solta)
    |> assign(:form, to_form(Soltas.change_solta(socket.assigns.current_scope, solta)))
  end

  @impl true
  def handle_event("validate", %{"solta" => solta_params}, socket) do
    changeset =
      Soltas.change_solta(socket.assigns.current_scope, socket.assigns.solta, solta_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"solta" => solta_params}, socket) do
    save_solta(socket, socket.assigns.live_action, solta_params)
  end

  defp save_solta(socket, :edit, solta_params) do
    case Soltas.update_solta(socket.assigns.current_scope, socket.assigns.solta, solta_params) do
      {:ok, solta} ->
        {:noreply,
         socket
         |> put_flash(:info, "Solta updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, solta)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_solta(socket, :new, solta_params) do
    case Soltas.create_solta(socket.assigns.current_scope, solta_params) do
      {:ok, solta} ->
        {:noreply,
         socket
         |> put_flash(:info, "Solta created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, solta)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(scope, "index", _solta), do: ~p"/o/#{scope.organization.slug}/soltas"
  defp return_path(scope, "show", solta), do: ~p"/o/#{scope.organization.slug}/soltas/#{solta}"
end
