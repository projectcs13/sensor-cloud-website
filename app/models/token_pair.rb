class TokenPair
  # Serializes and deserializes the token.

  @refresh_token
  @access_token
  @expires_in
  @issued_at

  def update_token!(object)
    @refresh_token = object.refresh_token
    @access_token = object.access_token
    @expires_in = object.expires_in
    @issued_at = object.issued_at
  end

  def to_hash
    {
      :refresh_token => @refresh_token,
      :access_token => @access_token,
      :expires_in => @expires_in,
      :issued_at => Time.at(@issued_at)
    }
  end

  def access_token= token
    @access_token = token
  end

  def refresh_token= token
    @refresh_token = token
  end

  def expires_in= seconds
    @expires_in = seconds
  end

  def issued_at= time
    @issued_at = time
  end

  # Getters

  def access_token
    @access_token
  end

  def refresh_token
    @refresh_token
  end

end
