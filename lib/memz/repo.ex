defmodule Memz.Repo do
  use Ecto.Repo,
    otp_app: :memz,
    adapter: Ecto.Adapters.Postgres
end
