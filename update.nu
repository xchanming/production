http get https://api.github.com/repos/xchanming/core/tags | each {|item|
    let exitcode = do {^git rev-parse $item.name} | complete | get exit_code

    if ($exitcode != 0) {
        mut composerJson = open composer.json

        if ($item.name | (str contains "rc")) {
            $composerJson.minimum-stability = "RC"
        } else {
            $composerJson.minimum-stability = "stable"
        }
        $composerJson.require.cicada-ag/core = $item.name

        $composerJson | to json | save composer.json --force
        git add composer.json
        git commit -m $"Update cicada-ag/core to ($item.name)"
        git tag -m $"Release: ($item.name)" $item.name
        git reset --hard origin/trunk
    }
}
