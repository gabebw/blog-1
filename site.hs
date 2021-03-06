{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid ((<>))
import           Hakyll

main :: IO ()
main = hakyll $ do
    match (fromGlob "static/*" .||. fromGlob "static/**") $ do
        route $ gsubRoute "static/" $ const ""
        compile copyFileCompiler

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAllSnapshots "posts/*" "content"
            let indexCtx =
                  listField "posts" itemCtx (return posts) <>
                  defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/post-list.html" indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler

itemCtx = teaserCtx <> postCtx
postCtx = dateCtx <> defaultContext
teaserCtx = teaserField "teaser" "content"
dateCtx = dateField "date" "%B %e, %Y"
