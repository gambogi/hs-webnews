{-# LANGUAGE OverloadedStrings #-}

module CSH.Webnews.Requests where

import Network.Wreq
import Network.HTTP.Client
import OpenSSL.Session
import Network.HTTP.Client.OpenSSL
import Control.Lens
import Data.Aeson (toJSON)
import Data.Aeson.Lens (key, nth)
import Data.Text as T
import Data.ByteString.Lazy.Internal (ByteString)

sslmgr = opensslManagerSettings context

webnewsOptions :: Text -> Options
webnewsOptions key = ((defaults & header "Accept" `set` ["application/json"])
                            & param "api_key" `set` [key])
                            & param "api_agent" `set` ["csh.hs"]

baseGet :: String -> Text -> IO (Response ByteString)
baseGet endpoint key = withOpenSSL $ getWith opts url where
    url = "http://webnews.csh.rit.edu/" ++ endpoint
    opts = (webnewsOptions key) & manager `set` Left (sslmgr)

getUnreadCounts :: Text -> IO (Response ByteString)
getUnreadCounts = baseGet "unread_counts"

getNewsgroups :: Text -> IO (Response ByteString)
getNewsgroups = baseGet "newsgroups"

getNewsgroup :: String -> Text -> IO (Response ByteString)
getNewsgroup newsgroup = baseGet ("newsgroups/" ++ newsgroup)

getNewsgroupIndex :: String -> Text -> IO (Response ByteString)
getNewsgroupIndex newsgroup = baseGet (newsgroup ++ "/index")
