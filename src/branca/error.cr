module Branca
  module Error
    class TokenHasExpired < Exception
    end

    class InvaildKeySize < Exception
    end

    class InvaildVersion < Exception
    end

    class InvaildToken < Exception
    end

    class Base62UnexpectedChar < Exception
    end
  end
end
