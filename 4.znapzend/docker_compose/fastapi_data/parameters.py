import yaml

class Parameters ():
     def __init__ ( self ):

         self.public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApLqZt5DfVKzy1O2x8h2VjOxKBFBjU/bcPRP3nhdkO/FjRoY3vv9gOMjB5R71yZ33Agx19QqL7gUWYMKICwmbXcM1/z9hToIEzXQBiqsdzhgUcFFSQw383hGdOrgeerIJqYYtXvbZUcrf8whDd5D+pykXqcEQM7qXm6lGteRFqegE1rDSyZyMm1HeIyxaTc5RcoskCDKaKc76MHNJWBZD+ut6VX0zjyGesLiIsSSnWqrWVZKYIc0SZ4Kc7CUHYrfnA+N0lwUS2lSHdXC6ZXNVLKxak+QCQgO6blVwmYLfR/dRzogDj0tnRjuTqKTeFw+L0Wt627mwcGwy27GJyfbqUQIDAQAB"

         self.public_key = "-----BEGIN PUBLIC KEY-----\n{}\n-----END PUBLIC KEY-----".format ( self.public_key )

         # https://www.janua.fr/keycloak-access-token-verification-example/
         # https://jwt.io/
         # https://pypi.org/project/jwt/
         # https://pypi.org/project/PyJWT/

     def read_docker_compose_yml ( self ) :

        with open ( "docker-compose.yml" , 'r' ) as stream : self.parsed_yaml = yaml.safe_load ( stream )
        
