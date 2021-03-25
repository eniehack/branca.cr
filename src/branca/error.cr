module Branca
  module Error
    class TokenHasExpired < Exception
    end

    class InvaildNonce < Exception
    end

    class InvaildKeySize < Exception
    end

    class InvaildVersion < Exception
    end

    class InvaildTimestamp < Exception
    end

    class InvaildKey < Exception
    end

    class InvaildToken < Exception
    end

    class WrongKey < Exception
    end

    class Base62UnexpectedChar < Exception
    end
  end
end
