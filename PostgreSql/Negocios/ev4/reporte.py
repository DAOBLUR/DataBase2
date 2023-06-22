import psycopg2

if __name__ == '__main__':
    
    conexion = psycopg2.connect(host="localhost", database="negocios", user="postgres", password="admin")

    # Creamos el cursor con el objeto conexion
    cur = conexion.cursor()

    print('-------------------------------')
    print('1. categorias')
    print('2. productos')
    print('3. proveedores')

    val = input("Elige una opcion: ")
    if(val == '1'):
        cur.execute("select nombrecateria, descripcion from compras.categorias") 
        for nombrecateria, descripcion in cur.fetchall() :
            print('-',nombrecateria,':', descripcion)
    elif(val == '2'):
        cur.execute("select * from compras.productos")
    elif(val == '3'):
        cur.execute("select  from compras.proveedores",)
   
    conexion.close()
