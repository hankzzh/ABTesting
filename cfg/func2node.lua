return {
    level_100_enter = {
        ['$foreach'] = {
            {
                ['$get'] = {"nodecfg", "nodes"}
            },
            
            {
                ['$func'] = {
                    ['$if'] = {
                        ['$eq'] = {
                            
                        }
                    },
                    ['$set'] = "$2"
                }
            }
        }
    }
}