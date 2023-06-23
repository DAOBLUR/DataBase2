// POSTGRESQL: node i pg
const { Pool } = require('pg');

const config = {
    host: 'localhost',
    user: 'postgres',
    password: 'admin',
    database: 'negocios',
    port: 5432
};

const pool = new Pool(config);
const pool2 = new Pool(config);
//INPUT
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin, output: process.stdout
});

//
async function SelectAll(table) {
    try {
        const res = await pool.query(`select * from ${table}`);
        for(var i in res.rows){
            console.log(res.rows[i])
        }
        pool.end();
    } 
    catch(e) {
        console.log('Error:')
        console.log(e);
    }
}

async function Select(id,idtable,table) {
    try {
        const res = await pool.query(`select * from ${table} where ${idtable} = ${id}`);
        for(var i in res.rows){
            console.log(res.rows[i])
        }
        pool.end();
    } 
    catch(e) {
        console.log('Error:')
        console.log(e);
    }
}

async function InsertarCargo(nombre, bonificacion) {
    try {
        const text = 'call rrhh.Insertar_Cargo($1, $2)';
        const values = [nombre, bonificacion];
        const res = await pool.query(text, values);
        console.log('Success \n',res)
        pool.end();
    } 
    catch (e) {
        console.log('Error\n',e);
    }
};

async function ActualizarCargo(id, nombre, bonificacion) {
    try {
        const text = 'call rrhh.Actualizar_Cargo($1, $2, $3)';
        const values = [id, nombre, bonificacion];
        const res = await pool2.query(text, values);
        console.log('Success \n',res)
        pool2.end();
    } 
    catch (e) {
        console.log('Error\n',e);
    }
};

async function EliminarCargo(id) {
    try {
        const text = 'call rrhh.Eliminar_Cargo($1)';
        const values = [id];
        const res = await pool2.query(text, values);
        console.log('Success \n',res)
        pool2.end();
    } 
    catch (e) {
        console.log('Error\n',e);
    }
};

async function SeleccionarProveedorProductos(id) {
    try {
        const text = 'select * from obtener_proveedor_productos($1)';
        const values = [id];
        const res = await pool.query(text, values);
        for(var i in res.rows){
            console.log(res.rows[i])
        }
        pool.end();
    } 
    catch (e) {
        console.log('Error\n',e);
    }
};

async function mostrar_empleado_comision(id,comision) {
    try {
        const text = 'select mostrar_empleado_comision($1,$2)';
        const values = [id,comision];
        const res = await pool.query(text, values);
        pool.on('notice', (notice) => {
            console.log('Mensaje de notificación del procedimiento almacenado:', notice.message);
          });

        for(var i in res.rows){
            console.log(res.rows[i])
        }
        pool.end();
    } 
    catch (e) {
        console.log('Error\n',e);
    }
};

const question = (query) => new Promise((resolve) => rl.question(query, resolve));

async function Main() {
    console.log('╔═══════════════════════════════════╗');
    console.log('║             CONSULTAS             ║');
    console.log('╠═══════════════════════════════════╣');
    console.log('║ 1. Categorías                     ║');
    console.log('║ 2. Productos                      ║');
    console.log('║ 3. Proveedores                    ║');
    console.log('║ 4. Cargos                         ║');
    console.log('║ 5. Distritos                      ║');
    console.log('║ 6. Empleados                      ║');
    console.log('║ 7. Clientes                       ║');
    console.log('║ 8. Pedidos                        ║');
    console.log('╠═══════════════════════════════════╣');
    console.log('║              CARGOS               ║');
    console.log('╠═══════════════════════════════════╣');
    console.log('║ 9. Insertar                       ║');
    console.log('║ 10. Actualizar                    ║');
    console.log('║ 11. Eliminar                      ║');
    console.log('╠═══════════════════════════════════╣');
    console.log('║             REPORTES              ║');
    console.log('╠═══════════════════════════════════╣');
    console.log('║ 12. SeleccionarProveedorProductos ║');
    console.log('╚═══════════════════════════════════╝')

    const opcion = await question('Ingrese la Opcion: ');
    console.log(opcion)
    switch (opcion) {
        case '1':
            SelectAll('compras.categorias');
            break;
        case '2':
            SelectAll('compras.productos');
            break;
        case '3':
            SelectAll('compras.proveedores');
            break;
        case '4':
            SelectAll('rrhh.cargos');
            break;
        case '5':
            SelectAll('rrhh.distritos');
            break;
        case '6':
            SelectAll('rrhh.empleados');
            break;
        case '7':
            SelectAll('ventas.clientes');
            break;
        case '8':
            SelectAll('ventas.pedidoscabe');
            break;
        // CARGOS
        case '9':
            const inombre = await question('Ingrese un nombre: ');
            const ibonificacion = await question('Ingrese la bonificacion: ');
            InsertarCargo(inombre,ibonificacion);
            break;
        case '10':
            const aid = await question('Ingrese el ID: ');
            await Select(aid,'idcargo','rrhh.cargos');
            const anombre = await question('Ingrese un nombre: ');
            const abonificacion = await question('Ingrese la bonificacion: ');
            ActualizarCargo(aid,anombre,abonificacion);
            break;
        case '11':
            const did = await question('Ingrese el ID: ');
            EliminarCargo(did);
            break;
        case '12':
            const cid = await question('Ingrese el ID: ');
            SeleccionarProveedorProductos(cid);
            break;
        default:
            console.log('Input Error');
    }
    rl.close();
}

//Main();
mostrar_empleado_comision(1,10)