defmodule RocketpayWeb.AccountsControllerTest do
  use RocketpayWeb.ConnCase, async: true

  alias Rocketpay.{Account, User}

  describe "deposit/2" do
    setup %{conn: conn} do
      user_params = %{
        name: "Rafael",
        password: "123456",
        nickname: "camarda",
        email: "rafael@banana.com",
        age: 27
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(user_params)

      conn = put_req_header(conn, "authorization", "Basic YmFuYW5hOm5hbmljYTEyMw==")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, make the deposit", %{conn: conn, account_id: account_id} do
      params = %{"value" => "50.00"}

      response = conn
      |> post(Routes.accounts_path(conn, :deposit, account_id, params))
      |> json_response(:ok)

      assert  %{
          "account" => %{"balance" => "50.00", "id" => _id},
          "message" => "Balance changed successfully"
        } = response
    end

    test "when there are invalid params, returns an error", %{conn: conn, account_id: account_id} do
      params = %{"value" => "banana"}

      response = conn
      |> post(Routes.accounts_path(conn, :deposit, account_id, params))
      |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid deposit value!"}

      assert response == expected_response
    end
  end

  describe "withdraw/2" do
    setup %{conn: conn} do
      user_params = %{
        name: "Rafael",
        password: "123456",
        nickname: "camarda",
        email: "rafael@banana.com",
        age: 27
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(user_params)

      conn = put_req_header(conn, "authorization", "Basic YmFuYW5hOm5hbmljYTEyMw==")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, make the withdraw", %{conn: conn, account_id: account_id} do
      params = %{"value" => "50.00"}

      conn
      |> post(Routes.accounts_path(conn, :deposit, account_id, %{"value" => "100.00"}))
      |> json_response(:ok)

      response = conn
      |> post(Routes.accounts_path(conn, :withdraw, account_id, params))
      |> json_response(:ok)

      assert  %{
          "account" => %{"balance" => "50.00", "id" => _id},
          "message" => "Balance changed successfully"
        } = response
    end

    test "when withdraw value is bigger than user balance, do not make the operation", %{conn: conn, account_id: account_id} do
      params = %{"value" => "500.00"}

      response = conn
      |> post(Routes.accounts_path(conn, :withdraw, account_id, params))
      |> json_response(:bad_request)

      assert %{"message" => %{"balance" => ["is invalid"]}} = response
    end

    test "when there are invalid params, returns an error", %{conn: conn, account_id: account_id} do
      params = %{"value" => "banana"}

      response = conn
      |> post(Routes.accounts_path(conn, :deposit, account_id, params))
      |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid deposit value!"}

      assert response == expected_response
    end
  end

  describe "transaction/2" do
    setup %{conn: conn} do
      user1_params = %{
        name: "Rafael",
        password: "123456",
        nickname: "camarda",
        email: "rafael@banana.com",
        age: 27
      }

      user2_params = %{
        name: "Diego Fernandes",
        password: "123456",
        nickname: "diego",
        email: "diego@banana.com",
        age: 27
      }

      {:ok, %User{account: %Account{id: account1_id}}} = Rocketpay.create_user(user1_params)
      {:ok, %User{account: %Account{id: account2_id}}} = Rocketpay.create_user(user2_params)

      conn = put_req_header(conn, "authorization", "Basic YmFuYW5hOm5hbmljYTEyMw==")

      {:ok, conn: conn, account1_id: account1_id, account2_id: account2_id}
    end

    test "when all params are valid, make the transaction", %{conn: conn, account1_id: account1_id, account2_id: account2_id} do
      params = %{"from" => account1_id, "to" => account2_id, "value" => "50.00"}

      conn
      |> post(Routes.accounts_path(conn, :deposit, account1_id, %{"value" => "100.00"}))
      |> json_response(:ok)

      response = conn
      |> post(Routes.accounts_path(conn, :transaction, params))
      |> json_response(:ok)

      assert  %{
          "message" => "Transaction done successfully",
          "transaction" => %{
            "from_account" => %{
              "id" => _id1,
              "balance" => "50.00"
            },
            "to_account" => %{
              "id" => _id2,
              "balance" => "50.00"
            }
          }
        } = response
    end

    test "when there is not enough balance, returns an error", %{conn: conn, account1_id: account1_id, account2_id: account2_id} do
      params = %{"from" => account1_id, "to" => account2_id, "value" => "50.00"}

      response = conn
      |> post(Routes.accounts_path(conn, :transaction, params))
      |> json_response(:bad_request)

      assert %{"message" => %{"balance" => ["is invalid"]}} = response
    end

    test "when there are invalid params, returns an error", %{conn: conn, account1_id: account1_id, account2_id: account2_id} do
      params = %{"from" => account1_id, "to" => account2_id, "value" => "banana"}

      conn
      |> post(Routes.accounts_path(conn, :deposit, account1_id, %{"value" => "100.00"}))
      |> json_response(:ok)

      response = conn
      |> post(Routes.accounts_path(conn, :transaction, params))
      |> json_response(:bad_request)

      assert %{
          "message" => "Invalid deposit value!"
        } = response
    end
  end
end
