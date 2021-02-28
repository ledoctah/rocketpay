defmodule RocketpayWeb.UsersControllerTest do
  use RocketpayWeb.ConnCase, async: true

  describe "create/2" do
    test "when all params are valid, create an user", %{conn: conn} do
      params = %{
        "name" => "Diego Fernandes",
        "nickname" => "diegofernandes",
        "email" => "diegofernandes@rocketseat.com",
        "age" => 27,
        "password" => "123456"
      }

      response = conn
      |> post(Routes.users_path(conn, :create, params))
      |> json_response(:created)

      assert %{
        "message" => "User created",
        "user" => %{
          "account" => %{
            "balance" => "0.00",
          },
          "name" => "Diego Fernandes",
          "nickname" => "diegofernandes"
        }
      } = response
    end

    test "when email already been used, return an error", %{conn: conn} do
      params1 = %{
        "name" => "Diego",
        "nickname" => "diegofernandes",
        "email" => "diegofernandes@rocketseat.com",
        "age" => 27,
        "password" => "123456"
      }

      params2 = %{
        "name" => "Diego Fernandes",
        "nickname" => "diegofernandes",
        "email" => "diegofernandes@rocketseat.com",
        "age" => 27,
        "password" => "123456"
      }

      conn
      |> post(Routes.users_path(conn, :create, params1))
      |> json_response(:created)

      response = conn
      |> post(Routes.users_path(conn, :create, params2))
      |> json_response(:bad_request)

      assert %{"message" => %{"email" => ["has already been taken"]}} = response
    end

    test "when nickname already been used, return an error", %{conn: conn} do
      params1 = %{
        "name" => "Diego",
        "nickname" => "diegofernandes",
        "email" => "diego@rocketseat.com",
        "age" => 27,
        "password" => "123456"
      }

      params2 = %{
        "name" => "Diego Fernandes",
        "nickname" => "diegofernandes",
        "email" => "diegofernandes@rocketseat.com",
        "age" => 27,
        "password" => "123456"
      }

      conn
      |> post(Routes.users_path(conn, :create, params1))
      |> json_response(:created)

      response = conn
      |> post(Routes.users_path(conn, :create, params2))
      |> json_response(:bad_request)

      assert %{"message" => %{"nickname" => ["has already been taken"]}} = response
    end

    test "when there are a password shorthen than 6 characters, return an error", %{conn: conn} do
      params = %{
        "name" => "Diego",
        "nickname" => "diegofernandes",
        "email" => "diego@rocketseat.com",
        "age" => 27,
        "password" => "123"
      }

      response = conn
      |> post(Routes.users_path(conn, :create, params))
      |> json_response(:bad_request)

      assert %{
        "message" => %{
          "password" => ["should be at least 6 character(s)"]
        }
      } = response
    end

    test "when there invalid params, return an error", %{conn: conn} do
      params = %{
        "name" => "Diego",
        "nickname" => "diegofernandes",
        "email" => "diego@rocketseat.com",
        "age" => "banana",
        "password" => "123456"
      }

      response = conn
      |> post(Routes.users_path(conn, :create, params))
      |> json_response(:bad_request)

      assert %{"message" => %{"age" => ["is invalid"]}} = response
    end
  end
end
