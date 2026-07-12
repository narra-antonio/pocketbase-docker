/// <reference path="../pb_data/types.d.ts" />

// Fixture Test 2 — collection utente con nome "difficile" (prefisso numerico basso)
migrate((app) => {
    const collection = new Collection({
        name: 'tabella',
        type: 'base',
        fields: [
            { name: 'nome', type: 'text', required: true },
            { name: 'valore', type: 'number' },
        ],
    })
    app.save(collection)
    console.log('✅ [fixture] collection "tabella" creata')
}, (app) => {
    const collection = app.findCollectionByNameOrId('tabella')
    app.delete(collection)
})
