@.taigaContribPlugins = @.taigaContribPlugins or []

googleAuthInfo = {
    slug: "google-auth"
    name: "Google Auth"
    type: "auth"
    module: "taigaContrib.googleAuth"
    template: "contrib/google_auth"
}

@.taigaContribPlugins.push(googleAuthInfo)

module = angular.module('taigaContrib.googleAuth', [])

AUTH_URL = "https://google.com/login/oauth/authorize"

GoogleLoginButtonDirective = ($window, $params, $location, $config, $events, $confirm, $auth, $navUrls, $loader) ->
    # Login or registar a user with his/her google account.
    #
    # Example:
    #     tg-google-login-button()
    #
    # Requirements:
    #   - ...

    link = ($scope, $el, $attrs) ->
        clientId = $config.get("googleClientId", null)

        loginOnSuccess = (response) ->
            if $params.next and $params.next != $navUrls.resolve("login")
                nextUrl = $params.next
            else
                nextUrl = $navUrls.resolve("home")

            $events.setupConnection()

            $location.search("next", null)
            $location.search("token", null)
            $location.search("state", null)
            $location.search("code", null)
            $location.path(nextUrl)

        loginOnError = (response) ->
            $location.search("state", null)
            $location.search("code", null)
            $loader.pageLoaded()

            if response.data.error_message
                $confirm.notify("light-error", response.data.error_message )
            else
                $confirm.notify("light-error", "Our Oompa Loompas have not been able to get you
                                                credentials from Google.")  #TODO: i18n

        loginWithGoogleAccount = ->
            type = $params.state
            code = $params.code
            token = $params.token

            return if not (type == "google" and code)
            $loader.start()

            data = {code: code, token: token}
            $auth.login(data, type).then(loginOnSuccess, loginOnError)

        loginWithGoogleAccount()

        $el.on "click", ".button-auth", (event) ->
            redirectToUri = $location.absUrl()
            url = "#{AUTH_URL}?client_id=#{clientId}&redirect_uri=#{redirectToUri}&state=google&scope=user:email"
            $window.location.href = url

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        template: ""
    }

module.directive("tgGoogleLoginButton", ["$window", '$routeParams', "$tgLocation", "$tgConfig", "$tgEvents",
                                         "$tgConfirm", "$tgAuth", "$tgNavUrls", "tgLoader",
                                         GoogleLoginButtonDirective])
