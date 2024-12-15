return {
    level_100_enter = {
        ['$foreach'] = {
            {
                ['$getg'] = {"nodecfg", "nodes"}
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