xquery version "3.1";

module namespace av="http://hxwd.org/api/view";

import module namespace config="http://hxwd.org/apps/ro-test/config" at "config.xqm";
import module namespace errors = "http://e-editiones.org/roaster/errors";
import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace log="http://hxwd.org/log" at "log.xql";
import module namespace app="http://hxwd.org/apps/ro-test/templates" at "app.xqm";

declare variable $av:log :=  "/db/tmp/app";


declare variable  $av:config := map {
    $templates:CONFIG_APP_ROOT : $config:app-root,
    $templates:CONFIG_STOP_ON_ERROR : true()
};


declare function av:lookup($name as xs:string, $arity as xs:int) {
    try {
    (: disabling custom API for the moment :)
         let $cfun := ()
(:        let $cfun := custom:lookup($name, $arity):)
        return
            if (empty($cfun)) then
                function-lookup(xs:QName($name), $arity)
            else
                $cfun
    } catch * {
        ()
    }
};


declare function av:html($request as map(*)) {
    let $path := $config:app-root || "/" || xmldb:decode($request?parameters?file) || ".html"
    , $log := log:info($av:log, "Path is " || $path)
    let $template :=
        if (doc-available($path)) then
            doc($path)
        else
            error($errors:NOT_FOUND, "HTML file " || $path || " not found")
    return
        templates:apply($template, av:lookup#2, (), $av:config)
};

declare function av:handle-error($error) {
    let $path := $config:app-root || "/error-page.html"
    , $log := log:info($av:log, "Path is " || $path)
    let $template := doc($path)
    return
        templates:apply($template, av:lookup#2, map { "description": $error }, $av:config)
};