module AuthHelper
  def authenticated_headers(user)
    # Sign Up the User
    post '/auth', params: {
      email: user.email,
      password: 'password',
      password_confirmation: 'password'
    }

    # Log In the User
    post '/auth/sign_in', params: { email: user.email, password: 'password' }

    JSON.parse(response.body)

    {
      'uid' => response.headers['uid'],
      'client' => response.headers['client'],
      'access-token' => response.headers['access-token'],
      'token-type' => response.headers['token-type']
    }
  end
end