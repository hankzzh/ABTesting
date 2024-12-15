return {
    level_100_enter = {
        ['$foreach'] = {
            {
                ['$get'] = {"nodecfg", "nodes"}
            },
            
            {
                ['$func'] = {
                    ['$set'] = "$1"
                }
            }
        }
    }
}