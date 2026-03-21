defmodule OddishWeb.VisitLive.Form do
  use OddishWeb, :live_view

  alias Oddish.Medicine
  alias Oddish.Medicine.Visit

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage visit records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="visit-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:vet_id]} type="number" label="Vet" />
        <.input field={@form[:procedure_id]} type="number" label="Procedure" />
        <.input field={@form[:bovine_id]} type="text" label="Bovine" />
        <.input field={@form[:date]} type="date" label="Date" />
        <.input field={@form[:notes]} type="textarea" label="Notes" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Visit</.button>
          <.button navigate={return_path(@current_scope, @return_to, @visit)}>Cancel</.button>
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
    visit = Medicine.get_visit!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Visit")
    |> assign(:visit, visit)
    |> assign(:form, to_form(Medicine.change_visit(socket.assigns.current_scope, visit)))
  end

  defp apply_action(socket, :new, _params) do
    visit = %Visit{org_id: socket.assigns.current_scope.organization.id}

    socket
    |> assign(:page_title, "New Visit")
    |> assign(:visit, visit)
    |> assign(:form, to_form(Medicine.change_visit(socket.assigns.current_scope, visit)))
  end

  @impl true
  def handle_event("validate", %{"visit" => visit_params}, socket) do
    changeset =
      Medicine.change_visit(socket.assigns.current_scope, socket.assigns.visit, visit_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"visit" => visit_params}, socket) do
    save_visit(socket, socket.assigns.live_action, visit_params)
  end

  defp save_visit(socket, :edit, visit_params) do
    case Medicine.update_visit(socket.assigns.current_scope, socket.assigns.visit, visit_params) do
      {:ok, visit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Visit updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, visit)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_visit(socket, :new, visit_params) do
    case Medicine.create_visit(socket.assigns.current_scope, visit_params) do
      {:ok, visit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Visit created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, visit)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(scope, "index", _visit), do: ~p"/o/#{scope.organization.slug}/visits"
  defp return_path(scope, "show", visit), do: ~p"/o/#{scope.organization.slug}/visits/#{visit}"
end
