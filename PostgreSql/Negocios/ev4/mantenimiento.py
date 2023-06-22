import psycopg2

def ObtenerFecha():
    dia = input("Ingresa el dia: ")
    mes = input("Ingresa el mes: ")
    anio = input("Ingresa el año: ")
    return "'"+anio+'-'+mes+'-'+dia+"'"


if __name__ == '__main__':
    
    conexion = psycopg2.connect(host="localhost", database="bd_clinica", user="postgres", password="admin")

    # Creamos el cursor con el objeto conexion
    cur = conexion.cursor()

    print('---------EQUIPAMIENTOS---------')
    print('-------------------------------')
    print('1. Insertar')
    print('2. Eliminar')
    print('3. Actualizar')
    print('4. close')

    val = input("Elige una opcion: ")
    if(val == '1'):
        cur.execute( "SELECT COUNT(*) AS NUMERO FROM EQUIPAMIENTOS")

        NUMERO_EQUIPAMIENTO = str(cur.fetchall()[0][0] + 1)
        ID_TIPO = input("Ingresa el ID_TIPO: ")
        NUMERO_CONSULTORIO = input("Ingresa el NUMERO_CONSULTORIO: ")
        FECHA_MANTENIMIENTO = ObtenerFecha()

        cur.execute("call insertar_equipamiento(%s,%s,%s,%s)",(NUMERO_EQUIPAMIENTO,ID_TIPO,NUMERO_CONSULTORIO,FECHA_MANTENIMIENTO))

    elif(val == '2'):
        NUMERO_EQUIPAMIENTO = input("Ingresa el NUMERO_EQUIPAMIENTO: ")
        cur.execute("call eliminar_equipamiento(%s)",NUMERO_EQUIPAMIENTO)
    elif(val == '3'):
        NUMERO_EQUIPAMIENTO = input("Ingresa el NUMERO_EQUIPAMIENTO: ")
        ID_TIPO = input("Ingresa el ID_TIPO: ")
        NUMERO_CONSULTORIO = input("Ingresa el NUMERO_CONSULTORIO: ")
        FECHA_MANTENIMIENTO = ObtenerFecha()
        cur.execute("call actualizar_equipamiento(%s,%s,%s,%s)",(NUMERO_EQUIPAMIENTO,ID_TIPO,NUMERO_CONSULTORIO,FECHA_MANTENIMIENTO))
    else:
        conexion.close()
