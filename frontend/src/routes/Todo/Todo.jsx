import * as services from "../../services/todo-services";
import { useEffect, useState } from "react";
import TodoItem from "../../components/TodoItem/TodoItem";
import Title from "../../components/Title/Title";
import "./Todo.scss";

// Test2

export default function Todo() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [newTodo, setNewTodo] = useState("");

  useEffect(() => {
    readData();
  }, []); // Empty Array ensures the useEffect will only run Once!

  const readData = async () => {
    setLoading(true);
    const res = await services.readTodo();
    console.log(res.data);
    setData(res.data);
    setLoading(false);
  };

  const createData = async () => {
    const res = await services.createTodo(newTodo);
    setData([...data, res.data]);
    setNewTodo("");
  };

  const deleteData = async (id) => {
    const res = await services.deleteTodo(id)
    const d = [...data];
    const i = d.findIndex((el) => el._id === id);
    if (i !== -1) {
      d.splice(i, 1);
    }
    setData(d);
  };

  const updateData = async ({ id, isDone, todo }) => {
    const res = await services.updateTodo(id, {
      todo: todo,
      isDone: isDone,
    });
    const d = [...data];
    const i = d.findIndex((el) => el._id === id);
    if (i !== -1) {
      d[i] = res.data;
    }
    setData(d);
  };

  const handleEnterKey = async (e) => {
    if (e.key === "Enter") {
      console.log("do validate");
      createData();
    }
  };

  const handleChange = async (id, name, value) => {
    updateData({ id, [name]: value });
  };

  if (loading) {
    return "loading...";
  }

  return (
    <div className="container-fluid home-container">
      <div className="row">
        <div className="col-sm-12">
          <div className="title-container d-flex" data-testid="ProjectTitle">
            <Title title="Tasks"/>
            <button
            data-testid="AddNewTodo"
              className="btn btn-primary ml-auto"
              onClick={() => createData()}
            >
              Add New
            </button>
          </div>
        </div>
      </div>
      <div className="row">
        <div className="col-sm-12">
          <div className="tasks-container margin-top-20">
            <input
            data-testid="EnterTodoItem"
              onChange={(e) => {
                setNewTodo(e.target.value);
              }}
              value={newTodo}
              onKeyUp={handleEnterKey}
              type="text"
              placeholder="Enter Todo item"
              className="form-control margin-bottom-20 padding-20"
            />
            {data?.map((el, i) => (
              <TodoItem
                onChange={(name, value) => {
                  handleChange(el._id, name, value);
                }}
                onDelete={() => {
                  deleteData(el._id);
                }}
                title={el.todo}
                isDone={el.isDone}
                key={i}
              />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
