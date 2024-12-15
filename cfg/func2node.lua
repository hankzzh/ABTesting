return {
    level_100_enter = {
        ['$foreach'] = {
            {
                ['$getg'] = {"nodecfg", "nodes"}
            },
            {
                ['$func'] = {
                    ['$if'] = {
						{
							['$and'] = {
								{
									['$eq'] = {
										{ ['$get'] = { '$v', { 'level' } } },
										100,
									},
								},
								{
									['$type']
								}
							}
						},
						{
							['$set'] = { '$v', { 'enter' }, { ['$getg'] = { "func", "headaction" } } }
						}

                    },
                    ['$set'] = "$2"
                }
            }
        }
    }
}