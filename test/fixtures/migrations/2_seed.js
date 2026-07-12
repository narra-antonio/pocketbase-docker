/// <reference path="../pb_data/types.d.ts" />

// Fixture Test 2 — 50 record seed per la collection "tabella"
migrate((app) => {
    const collection = app.findCollectionByNameOrId('tabella')
    for (let i = 1; i <= 50; i++) {
        const record = new Record(collection)
        record.set('nome', 'item-' + i)
        record.set('valore', i)
        app.save(record)
    }
    console.log('✅ [fixture] 50 record seed inseriti in "tabella"')
}, (app) => {
    const collection = app.findCollectionByNameOrId('tabella')
    const records = app.findAllRecords('tabella')
    records.forEach((r) => app.delete(r))
})
