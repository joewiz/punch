xquery version "1.0";

(:~
    controller.xql for URL rewriting.
:)

(: Standard controller.xql variables passed in from the URL Rewriting framework :)

declare variable $exist:root external;
declare variable $exist:prefix external;
declare variable $exist:controller external;
declare variable $exist:path external;
declare variable $exist:resource external;

(: Log all URL Rewriting requests? :)
declare variable $local:log := true();

(: Cache all URL Rewriting paths? :)
declare variable $local:cache-control := 'no';

(: ---------------------------------------------------------------------------------- :)
(: Functions for handling the main URL Rewriting verbs: forward, redirect, and ignore :)
(: ---------------------------------------------------------------------------------- :)

declare function local:forward($controller, $relative-path as xs:string) {
    local:forward($controller, $relative-path, ())
};

declare function local:forward($controller as xs:string, $relative-path as xs:string, $attribs as element(exist:add-parameter)*) {
    let $absolute-path-from-controller := concat($controller, '/', $relative-path)
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$absolute-path-from-controller}">
                {$attribs}
            </forward>
            <cache-control cache="{$local:cache-control}"/>
        </dispatch>
};

declare function local:redirect($absolute-path as xs:string) {
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{$absolute-path}"/>
        <cache-control cache="{$local:cache-control}"/>
    </dispatch>
};

declare function local:add-parameter($name as xs:string, $value as xs:string) as element(exist:add-parameter) {
    <add-parameter xmlns="http://exist.sourceforge.net/NS/exist" name="{$name}" value="{$value}"/>
};

declare function local:ignore() {
    <ignore xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="{$local:cache-control}"/>
    </ignore>
};

declare function local:log-variables($params as element(params)) {
    for $param in $params/param
    let $name := string($param/@name)
    let $value := $param/text()
    return
        util:log("DEBUG", concat("URL Rewriter: ", $name, ":          ", $value))
};

(: Main routine :)

let $uri :=         request:get-uri()
let $context :=     request:get-context-path()
let $root :=        $exist:root
let $prefix :=      $exist:prefix
let $controller :=  $exist:controller
let $path :=        $exist:path
let $resource :=    $exist:resource

return

    (: Handle initial requests to the app :)
    if ($path = '') then
        local:redirect(concat($context, $prefix, $controller, '/'))
    else if ($path = '/') then
        local:redirect('./index.xq')

    (: Catch requests for .xq files :)
    else if (ends-with($path, '.xq')) then
        let $web-path-to-app := concat($context, $prefix, $controller)
        let $db-path-to-site := $root
        let $db-path-to-app := concat($root, replace($controller, '^/', ''))
        let $db-path-to-app-data := concat($root, replace($controller, '^/', ''), '/', 'data')
        let $web-depth-in-site := xs:string(count(tokenize(substring-after($uri, $prefix), '/')) - 1)
        let $url-params :=
            <params>
                <param name="web-path-to-app">{$web-path-to-app}</param>
                <param name="db-path-to-site">{$db-path-to-site}</param>
                <param name="db-path-to-app">{$db-path-to-app}</param>
                <param name="db-path-to-app-data">{$db-path-to-app-data}</param>
                <param name="web-depth-in-site">{$web-depth-in-site}</param>
            </params>
        return
            (
            local:forward(
                $controller
                , 
                $path
                ,
                for $param in $url-params/param
                let $name := string($param/@name)
                let $value := string($param)
                return 
                    local:add-parameter($name, $value)
                )
            ,
            if ($local:log) then
                local:log-variables($url-params)
            else ()
            )
    
    (: everything else is passed through :)
    else
        (
        local:ignore()
        ,
        if ($local:log) then
            util:log("DEBUG", concat("URL Rewriter: ", " IGNORED:          ", $uri))
        else ()
        )